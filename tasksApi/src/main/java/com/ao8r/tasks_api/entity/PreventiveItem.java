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

    @Column(name = "app_name", nullable = false)
    private String appName;

    @Column(name = "action", nullable = false)
    private String action;
}