package com.ao8r.tasks_api.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "place_item")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlaceItem implements java.io.Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "place_name", nullable = false, columnDefinition = "NVARCHAR(255)")
    private String placeName;
}