package com.driverandrider.controller;

import com.driverandrider.service.PusherChannelsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * In-memory chat messages per trip.
 * Messages are stored while the server is running (no DB persistence needed for active trips).
 */
@RestController
@RequestMapping("/api/trips/{tripId}/messages")
@RequiredArgsConstructor
public class TripChatController {

    private static final Map<Long, CopyOnWriteArrayList<Map<String, Object>>> store =
            new ConcurrentHashMap<>();

    private final PusherChannelsService pusherChannelsService;

    /** GET /api/trips/{tripId}/messages — fetch all messages for a trip */
    @GetMapping
    public List<Map<String, Object>> getMessages(@PathVariable Long tripId) {
        return store.getOrDefault(tripId, new CopyOnWriteArrayList<>());
    }

    /** POST /api/trips/{tripId}/messages — send a message */
    @PostMapping
    public ResponseEntity<Map<String, Object>> sendMessage(
            @PathVariable Long tripId,
            @RequestBody Map<String, Object> msg) {

        msg.put("timestamp", LocalDateTime.now().toString());
        store.computeIfAbsent(tripId, k -> new CopyOnWriteArrayList<>()).add(msg);
        pusherChannelsService.broadcastChatMessage(tripId, msg);

        return ResponseEntity.status(HttpStatus.CREATED).body(msg);
    }
}
