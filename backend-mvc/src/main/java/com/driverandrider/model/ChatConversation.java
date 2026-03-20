package com.driverandrider.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "chat_conversations")
@Data
@NoArgsConstructor
public class ChatConversation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(columnDefinition = "chat_type", nullable = false)
    private ChatType type = ChatType.DIRECT;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "trip_id")
    private Trip trip; // optional — links chat to a specific trip

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "company_id")
    private Company company;

    private String branchId;

    @OneToMany(mappedBy = "conversation", cascade = CascadeType.ALL)
    private List<ChatParticipant> participants;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "last_message_id")
    private ChatMessage lastMessage;

    private String lastMessagePreview;
    private LocalDateTime lastMessageAt;
    private LocalDateTime createdAt = LocalDateTime.now();

    public enum ChatType {
        DIRECT, TRIP, SUPPORT
    }
}
