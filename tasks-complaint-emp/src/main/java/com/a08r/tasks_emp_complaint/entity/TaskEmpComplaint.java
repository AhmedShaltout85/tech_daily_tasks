package com.a08r.tasks_emp_complaint.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "task_emp_complaint")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TaskEmpComplaint implements java.io.Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "app_name", nullable = false)
    private String appName;

    @Column(name = "complaint_name", nullable = false)
    private String complaintName;

    @Column(name = "place_name", nullable = false)
    private String placeName;

    @Column(name = "department", nullable = false)
    private String department;

    @Column(name = "sub_place", nullable = false)
    private String subPlace;

    @Column(name = "emp_name", nullable = false)
    private String empName;

    @Column(name = "emp_number", nullable = false)
    private String empNumber;

    @Column(name = "emp_mobile", nullable = false)
    private String empMobile;

    @Column(name = "is_enable", nullable = false)
    private Boolean isEnable;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}
