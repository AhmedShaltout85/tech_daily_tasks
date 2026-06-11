package com.a08r.tasks_emp_complaint.service;

import com.a08r.tasks_emp_complaint.dto.AboutAppRequest;
import com.a08r.tasks_emp_complaint.dto.AboutAppResponse;

import java.util.List;

public interface AboutAppService {

    AboutAppResponse createItem(AboutAppRequest request);

    List<AboutAppResponse> getAllItems();

    AboutAppResponse getItemById(Long id);

    AboutAppResponse updateItem(Long id, AboutAppRequest request);

    void deleteItem(Long id);

    List<AboutAppResponse> getByAppName(String appName);

    List<AboutAppResponse> getByDepartment(String department);
}
