package com.ao8r.tasks_api.service;

import com.ao8r.tasks_api.dto.AppsNameRequest;
import com.ao8r.tasks_api.dto.AppsNameResponse;
import com.ao8r.tasks_api.entity.AppsName;

import java.util.List;
import java.util.Optional;

public interface AppsNameService {

    AppsNameResponse createApp(AppsNameRequest request);

    List<AppsNameResponse> getAllApps();

    Optional<AppsNameResponse> getAppById(Long id);

    AppsNameResponse updateApp(Long id, AppsNameRequest request);

    void deleteApp(Long id);

    List<AppsNameResponse> getAppsByDepartment(String department);
}