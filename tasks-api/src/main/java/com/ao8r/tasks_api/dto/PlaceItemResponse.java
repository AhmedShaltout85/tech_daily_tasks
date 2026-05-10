package com.ao8r.tasks_api.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlaceItemResponse {

    private Long id;
    private String placeName;
}