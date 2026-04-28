package com.ao8r.tasks_api.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "preventive_maintenance")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PreventiveMaintenance implements java.io.Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "app_name", nullable = false, columnDefinition = "NVARCHAR(255)")
    private String appName;

    @Column(name = "action", nullable = false, columnDefinition = "NVARCHAR(500)")
    private String action;

    @Column(name = "username", nullable = false, columnDefinition = "NVARCHAR(255)")
    private String username;

    @Column(name = "place_name", nullable = false, columnDefinition = "NVARCHAR(255)")
    private String placeName;

    @Column(name = "sub_place", columnDefinition = "NVARCHAR(255)")
    private String subPlace;

    @Column(name = "is_remote", nullable = false)
    private Boolean isRemote;

    @Column(name = "department", nullable = false, columnDefinition = "NVARCHAR(255)")
    private String department;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}