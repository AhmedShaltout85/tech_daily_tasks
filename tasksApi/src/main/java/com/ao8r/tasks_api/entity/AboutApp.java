package com.ao8r.tasks_api.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@Table(name = "about_app")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AboutApp implements java.io.Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "app_name", nullable = false, columnDefinition = "NVARCHAR(255)")
    private String appName;

    @Column(name = "department", nullable = false, columnDefinition = "NVARCHAR(255)")
    private String department;

    @ElementCollection
    @CollectionTable(name = "about_app_recommended", joinColumns = @JoinColumn(name = "about_app_id"))
    @Column(name = "recommended_value", columnDefinition = "NVARCHAR(500)")
    private List<String> recommended;
}