package com.ao8r.tasks_api.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "preventive_item")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PreventiveItem implements java.io.Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "app_name", nullable = false, columnDefinition = "NVARCHAR(255)")
    private String appName;

    @Column(name = "action", nullable = false, columnDefinition = "NVARCHAR(500)")
    private String action;

    @Column(name = "department", nullable = false, columnDefinition = "NVARCHAR(255)")
    private String department;
}