package com.ao8r.tasks_api.service;

import com.ao8r.tasks_api.dto.AboutAppRequest;
import com.ao8r.tasks_api.dto.AboutAppResponse;

import java.util.List;

public interface AboutAppService {

    AboutAppResponse createApp(AboutAppRequest request);

    List<AboutAppResponse> getAllApps();

    AboutAppResponse getAppById(Long id);

    AboutAppResponse getAppByAppName(String appName);

    List<String> getRecommendedByAppName(String appName);

    AboutAppResponse updateApp(Long id, AboutAppRequest request);

    void deleteApp(Long id);

    List<AboutAppResponse> getAppsByDepartment(String department);
}