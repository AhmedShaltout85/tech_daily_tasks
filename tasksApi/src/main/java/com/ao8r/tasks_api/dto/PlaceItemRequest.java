package com.ao8r.tasks_api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlaceItemRequest {

    @NotBlank(message = "Place name is required")
    @Size(max = 255, message = "Place name must not exceed 255 characters")
    private String placeName;
}