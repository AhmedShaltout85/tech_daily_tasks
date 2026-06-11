package com.a08r.tasks_emp_complaint.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AboutAppResponse {

    private Long id;
    private String appName;
    private String recommended;
    private String department;
}
