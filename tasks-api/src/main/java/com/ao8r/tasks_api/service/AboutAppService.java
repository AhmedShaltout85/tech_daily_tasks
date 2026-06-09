package com.ao8r.tasks_api.service;

import com.ao8r.tasks_api.dto.AboutAppRequest;
import com.ao8r.tasks_api.dto.AboutAppResponse;
import com.ao8r.tasks_api.dto.RecommendedResponse;

import java.util.List;

public interface AboutAppService {

    AboutAppResponse createApp(AboutAppRequest request);

    List<AboutAppResponse> getAllApps();
    List<AboutAppResponse> getAllAppsByDepartment(String department);


    AboutAppResponse getAppById(Long id);

    AboutAppResponse getAppByAppName(String appName);

    List<String> getRecommendedByAppName(String appName);

    List<RecommendedResponse> getAllRecommendedByAppName(String appName);

    void addRecommended(String appName, String recommendedValue);

    void deleteRecommended(Long id);

    AboutAppResponse updateApp(Long id, AboutAppRequest request);

    void deleteApp(Long id);
}