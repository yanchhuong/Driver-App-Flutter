package com.driverandrider.service;

import com.pusher.pushnotifications.PushNotifications;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@Slf4j
public class PusherBeamsService {

    @Value("${pusher.beams.instance-id}")
    private String instanceId;

    @Value("${pusher.beams.secret-key}")
    private String secretKey;

    private PushNotifications beams;

    @PostConstruct
    public void init() {
        beams = new PushNotifications(instanceId, secretKey);
        log.info("Pusher Beams initialized — instance: {}", instanceId);
    }

    // ── Public methods ────────────────────────────────────────

    /** Notify all drivers about a new trip request. Interest: "drivers" */
    public void notifyNewTripRequest(Long tripId, String pickup) {
        publish(
            List.of("drivers"),
            "New Trip Request",
            "Pickup: " + orDefault(pickup, "Location pending") + " — Trip #" + tripId
        );
    }

    /** Notify a specific rider that their trip was accepted. Interest: "rider-{id}" */
    public void notifyTripAccepted(Long riderId, String driverName) {
        publish(
            List.of("rider-" + riderId),
            "Driver is on the way",
            orDefault(driverName, "Your driver") + " accepted your trip"
        );
    }

    /** Notify a specific rider that their trip has started. Interest: "rider-{id}" */
    public void notifyTripStarted(Long riderId) {
        publish(
            List.of("rider-" + riderId),
            "Trip Started",
            "Your trip is now in progress"
        );
    }

    /** Notify a specific rider that their trip is complete. Interest: "rider-{id}" */
    public void notifyTripCompleted(Long riderId, Double fareAmount) {
        final String fare = fareAmount != null
            ? String.format("$%.2f", fareAmount)
            : "—";
        publish(
            List.of("rider-" + riderId),
            "Trip Completed",
            "Your trip is complete. Fare: " + fare
        );
    }

    /** Notify relevant parties of a cancellation. */
    public void notifyTripCancelled(Long riderId) {
        publish(
            List.of("rider-" + riderId),
            "Trip Cancelled",
            "Your trip has been cancelled"
        );
    }

    // ── Private helpers ───────────────────────────────────────

    private void publish(List<String> interests, String title, String body) {
        try {
            Map<String, Object> notification = new HashMap<>();
            notification.put("title", title);
            notification.put("body", body);

            // FCM (Android)
            Map<String, Object> fcm = new HashMap<>();
            fcm.put("notification", notification);

            // APNs (iOS)
            Map<String, Object> aps = new HashMap<>();
            aps.put("alert", notification);
            Map<String, Object> apns = new HashMap<>();
            apns.put("aps", aps);

            // Web push
            Map<String, Object> web = new HashMap<>();
            web.put("notification", notification);

            Map<String, Object> publishBody = new HashMap<>();
            publishBody.put("fcm", fcm);
            publishBody.put("apns", apns);
            publishBody.put("web", web);

            beams.publishToInterests(interests, publishBody);
            log.debug("Pusher Beams → interests={} title={}", interests, title);
        } catch (Exception e) {
            // Non-fatal — log but don't break the API response
            log.warn("Pusher Beams publish failed for interests {}: {}", interests, e.getMessage());
        }
    }

    private String orDefault(String value, String fallback) {
        return (value != null && !value.isBlank()) ? value : fallback;
    }
}
