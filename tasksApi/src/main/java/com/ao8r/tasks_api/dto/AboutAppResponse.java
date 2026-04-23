package com.ao8r.tasks_api.dto;

import lombok.*;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AboutAppResponse {

    private Long id;
    private String appName;
    private String department;
    private List<String> recommended;
}