package com.ao8r.tasks_api.dto;

import lombok.*;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PreventiveMaintenanceResponse {

    private Long id;
    private String appName;
    private String action;
    private String username;
    private String placeName;
    private String subPlace;
    private Boolean isRemote;
    private LocalDateTime createdAt;
}