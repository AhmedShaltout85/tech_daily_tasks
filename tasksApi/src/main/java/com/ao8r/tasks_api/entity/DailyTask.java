package com.ao8r.tasks_api.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "daily_task")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DailyTask implements java.io.Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "task_title", nullable = false)
    private String taskTitle;

    @Column(name = "task_status", nullable = false)
    private boolean taskStatus;

    @Column(name = "app_name", nullable = false)
    private String appName;

    @Column(name = "visit_place", nullable = false)
    private String visitPlace;

    @Column(name = "sub_place")
    private String subPlace;

    @Column(name = "assigned_to", nullable = false)
    private String assignedTo;

    @Column(name = "assigned_by", nullable = false)
    private String assignedBy;

    @Column(name = "co_operator", nullable = false)
    private String coOperator;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "expected_completion_date", nullable = false)
    private LocalDateTime expectedCompletionDate;

    @Column(name = "task_priority", nullable = false)
    private String taskPriority;

    @Column(name = "task_note")
    private String taskNote;

    @Column(name = "is_remote", nullable = false)
    private Boolean isRemote;
}
