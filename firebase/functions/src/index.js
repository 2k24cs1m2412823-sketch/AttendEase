const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

initializeApp();
const db = getFirestore();

/**
 * Damage Analysis — Suspect Identification
 *
 * Triggered when a new damage report is created.
 * Compares the report timestamp against the previous occupant
 * of the seat to determine if damage is pre-existing or suspect.
 *
 * Logic:
 *   - If damage reported within 5 minutes of sitting → GREEN (pre-existing)
 *   - If damage reported after previous occupant left → RED (suspect)
 */
exports.analyzeDamage = onDocumentCreated(
  "damage_reports/{reportId}",
  async (event) => {
    const report = event.data.data();
    const reportRef = event.data.ref;
    const { seat_id, reported_at, reported_by } = report;

    if (!reported_at || !seat_id) return;

    try {
      // Find the most recent attendance log for this seat before the report
      const prevAttendance = await db
        .collection("attendance_logs")
        .where("seat_id", "==", seat_id)
        .where("timestamp", "<", reported_at)
        .orderBy("timestamp", "desc")
        .limit(1)
        .get();

      if (prevAttendance.empty) {
        // No prior occupant found — cannot determine suspect
        await reportRef.update({
          analysis: "No prior occupant found for this seat.",
        });
        return;
      }

      const prevStudent = prevAttendance.docs[0].data();
      const timeDiffMs =
        reported_at.toMillis() - prevStudent.timestamp.toMillis();
      const FIVE_MINUTES_MS = 5 * 60 * 1000;

      if (timeDiffMs <= FIVE_MINUTES_MS) {
        // Damage reported quickly after sitting — likely pre-existing
        await reportRef.update({
          flag: "GREEN",
          analysis:
            `Damage reported ${Math.round(timeDiffMs / 1000)}s after ` +
            `sitting. Classified as pre-existing.`,
        });
      } else {
        // Damage discovered later — previous occupant is suspect
        await reportRef.update({
          flag: "RED",
          suspect_uid: prevStudent.student_id,
          analysis:
            `Seat was occupied by ${prevStudent.student_id}. ` +
            `Damage reported ${Math.round(timeDiffMs / 60000)} mins ` +
            `later by ${reported_by}. Flagged for review.`,
        });
      }
    } catch (error) {
      console.error("analyzeDamage error:", error);
    }
  }
);

/**
 * Session Cleanup — Auto-end stale sessions
 *
 * Can be triggered via Cloud Scheduler (cron) to end sessions
 * that have been active for more than 3 hours.
 */
exports.cleanupStaleSessions = require("firebase-functions/v2/scheduler")
  .onSchedule("every 60 minutes", async () => {
    const threeHoursAgo = new Date(Date.now() - 3 * 60 * 60 * 1000);

    const staleSessions = await db
      .collection("active_sessions")
      .where("is_active", "==", true)
      .where("started_at", "<", threeHoursAgo)
      .get();

    const batch = db.batch();
    staleSessions.docs.forEach((doc) => {
      batch.update(doc.ref, {
        is_active: false,
        ended_at: new Date(),
        end_reason: "auto_cleanup",
      });
    });

    await batch.commit();
    console.log(`Cleaned up ${staleSessions.size} stale sessions.`);
  });
