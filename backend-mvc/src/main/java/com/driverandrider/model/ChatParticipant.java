package com.driverandrider.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "chat_participants")
@Data
@NoArgsConstructor
public class ChatParticipant {

    @EmbeddedId
    private ChatParticipantId id = new ChatParticipantId();

    @ManyToOne
    @MapsId("conversationId")
    @JoinColumn(name = "conversation_id")
    private ChatConversation conversation;

    @ManyToOne
    @MapsId("userId")
    @JoinColumn(name = "user_id")
    private AppUser user;

    private LocalDateTime lastReadAt;
    private Boolean muted = false;
    private LocalDateTime joinedAt = LocalDateTime.now();

    @Embeddable
    @Data
    @NoArgsConstructor
    public static class ChatParticipantId implements Serializable {
        private Long conversationId;
        private Long userId;
    }
}
