package com.ao8r.tasks_api.entity;

import jakarta.persistence.*;
import lombok.*;

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

    @Column(name = "app_name", nullable = false)
    private String appName;

    @Column(name = "recommended", nullable = false)
    private String recommended;
}