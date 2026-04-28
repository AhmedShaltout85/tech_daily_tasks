package com.ao8r.tasks_api.entity;

import jakarta.persistence.*;
import lombok.*;
import java.io.Serializable;

@Entity
@Table(name = "apps_name")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AppsName implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "app_name", nullable = false, columnDefinition = "NVARCHAR(255)")
    private String appName;

    @Column(name = "department", nullable = false, columnDefinition = "NVARCHAR(255)")
    private String department;
}