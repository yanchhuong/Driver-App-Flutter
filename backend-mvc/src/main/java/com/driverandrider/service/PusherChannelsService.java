package com.driverandrider.service;

import com.pusher.rest.Pusher;
import com.driverandrider.model.Trip;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

/**
 * Broadcasts real-time events to connected Flutter clients via Pusher Channels (WebSocket).
 * All errors are caught and logged — publishing is non-fatal.
 *
 * Credentials: pusher.com → Your App → App Keys → fill in application.properties
 */
@Service
@Slf4j
public class PusherChannelsService {

    public static final String DRIVERS_CHANNEL = "drivers-channel";

    @Value("${pusher.channels.app-id}")
    private String appId;

    @Value("${pusher.channels.key}")
    private String key;

    @Value("${pusher.channels.secret}")
    private String secret;

    @Value("${pusher.channels.cluster}")
    private String cluster;

    private Pusher pusher;
    private boolean enabled = false;

    @PostConstruct
    public void init() {
        if (appId.startsWith("YOUR_")) {
            log.warn("Pusher Channels not configured — real-time events will be skipped. " +
                     "Fill in pusher.channels.* in application.properties.");
            return;
        }
        try {
            pusher = new Pusher(appId, key, secret);
            pusher.setCluster(cluster);
            pusher.setEncrypted(true);
            enabled = true;
            log.info("Pusher Channels ready — cluster={}", cluster);
        } catch (Exception e) {
            log.warn("Pusher Channels init failed: {}", e.getMessage());
        }
    }

    // ── Events ───────────────────────────────────────────────

    /**
     * Broadcast a new trip request to all drivers subscribed to drivers-channel.
     * Event: trip-requested  |  Channel: drivers-channel
     */
    public void broadcastTripRequested(Trip trip) {
        Map<String, Object> data = new HashMap<>();
        data.put("id",             trip.getId());
        data.put("tripType",       trip.getTripType().name());
        data.put("deliveryType",   trip.getDeliveryType() != null ? trip.getDeliveryType().name() : null);
        data.put("pickupAddress",  trip.getPickupAddress());
        data.put("dropoffAddress", trip.getDropoffAddress());
        data.put("fareAmount",     trip.getFareAmount());
        data.put("riderId",        trip.getRider().getId());
        data.put("riderName",      trip.getRider().getName());
        data.put("requestedAt",    trip.getRequestedAt() != null ? trip.getRequestedAt().toString() : null);
        trigger(DRIVERS_CHANNEL, "trip-requested", data);
    }

    /**
     * Tell drivers that a specific trip was already accepted (remove it from their queue).
     * Event: trip-accepted  |  Channel: drivers-channel
     */
    public void broadcastTripAccepted(Long tripId) {
        Map<String, Object> data = new HashMap<>();
        data.put("id", tripId);
        trigger(DRIVERS_CHANNEL, "trip-accepted", data);
    }

    /**
     * Tell drivers that a trip was cancelled (remove it from their queue).
     * Event: trip-cancelled  |  Channel: drivers-channel
     */
    public void broadcastTripCancelled(Long tripId) {
        Map<String, Object> data = new HashMap<>();
        data.put("id", tripId);
        trigger(DRIVERS_CHANNEL, "trip-cancelled", data);
    }

    /**
     * Notify a specific rider that their trip was accepted.
     * Event: trip-accepted-rider  |  Channel: rider-{riderId}
     */
    public void notifyRiderTripAccepted(Long riderId, Long tripId,
                                         String driverName, String driverPhone,
                                         String vehicleType, String vehiclePlate) {
        Map<String, Object> data = new HashMap<>();
        data.put("tripId",       tripId);
        data.put("driverName",   driverName);
        data.put("driverPhone",  driverPhone != null ? driverPhone : "");
        data.put("vehicleType",  vehicleType != null ? vehicleType : "");
        data.put("vehiclePlate", vehiclePlate != null ? vehiclePlate : "");
        trigger("rider-" + riderId, "trip-accepted-rider", data);
    }

    /**
     * Broadcast a trip lifecycle activity event to both the trip channel and the rider channel.
     * Event: trip-activity  |  Channel: trip-{tripId}, rider-{riderId}
     */
    public void broadcastTripActivity(Long tripId, Long riderId, String activityType) {
        Map<String, Object> data = new HashMap<>();
        data.put("tripId",       tripId);
        data.put("activityType", activityType);
        trigger("trip-" + tripId, "trip-activity", data);
        if (riderId != null) {
            trigger("rider-" + riderId, "trip-activity", data);
        }
    }

    /**
     * Broadcast a new chat message to all parties on a trip channel.
     * Event: new-message  |  Channel: trip-{tripId}
     */
    public void broadcastChatMessage(Long tripId, Map<String, Object> msg) {
        trigger("trip-" + tripId, "new-message", new HashMap<>(msg));
    }

    // ── Internals ────────────────────────────────────────────

    private void trigger(String channel, String event, Map<String, Object> data) {
        if (!enabled) return;
        try {
            pusher.trigger(channel, event, data);
            log.debug("Pusher Channels → {}/{}", channel, event);
        } catch (Exception e) {
            log.warn("Pusher Channels trigger failed ({}/{}): {}", channel, event, e.getMessage());
        }
    }
}
