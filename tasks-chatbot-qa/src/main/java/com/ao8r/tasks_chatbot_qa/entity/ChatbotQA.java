package com.ao8r.tasks_chatbot_qa.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "chatbot_qa")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatbotQA implements java.io.Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "question", nullable = false, length = 500)
    private String question;

    @Column(name = "answer", nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String answer;

    @Column(name = "category", length = 255)
    private String category;

    @Column(name = "display_order", nullable = false)
    private Integer displayOrder;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive;
}
