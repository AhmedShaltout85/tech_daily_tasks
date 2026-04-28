package com.ao8r.tasks_api.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "task_users")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "display_name", nullable = false, columnDefinition = "NVARCHAR(255)")
    private String displayName;

    @Column(nullable = false, columnDefinition = "NVARCHAR(255)")
    private String department;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, columnDefinition = "NVARCHAR(50)")
    private Role role;

    @Column(unique = true, nullable = false, columnDefinition = "NVARCHAR(255)")
    private String username;

    @Column(nullable = false, columnDefinition = "NVARCHAR(255)")
    private String password;

    @Column(name = "is_enable", nullable = false)
    @Builder.Default
    private boolean isEnabled = true;

    @Column(name = "created_at", nullable = false)
    @CreationTimestamp
    private LocalDateTime createdAt;
}
