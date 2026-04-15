package com.ao8r.tasks_api.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AboutAppResponse {

    private Long id;
    private String appName;
    private String recommended;
}