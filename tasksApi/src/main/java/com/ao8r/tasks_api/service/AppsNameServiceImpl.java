package com.ao8r.tasks_api.service;

import com.ao8r.tasks_api.dto.AppsNameRequest;
import com.ao8r.tasks_api.dto.AppsNameResponse;
import com.ao8r.tasks_api.entity.AppsName;
import com.ao8r.tasks_api.repository.AppsNameRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class AppsNameServiceImpl implements AppsNameService {

    private final AppsNameRepository appsNameRepository;

    @Override
    @Transactional
    public AppsNameResponse createApp(AppsNameRequest request) {
        log.debug("Creating new app with name: {} and department: {}", request.getAppName(), request.getDepartment());

        AppsName app = AppsName.builder()
                .appName(request.getAppName())
                .department(request.getDepartment())
                .build();

        AppsName savedApp = appsNameRepository.save(app);
        log.info("App created successfully with ID: {}", savedApp.getId());

        return AppsNameResponse.builder()
                .id(savedApp.getId())
                .appName(savedApp.getAppName())
                .department(savedApp.getDepartment())
                .build();
    }

    @Override
    public List<AppsNameResponse> getAllApps() {
        return appsNameRepository.findAll().stream()
                .map(app -> AppsNameResponse.builder()
                        .id(app.getId())
                        .appName(app.getAppName())
                        .department(app.getDepartment())
                        .build())
                .collect(Collectors.toList());
    }

    @Override
    public Optional<AppsNameResponse> getAppById(Long id) {
        return appsNameRepository.findById(id)
                .map(app -> AppsNameResponse.builder()
                        .id(app.getId())
                        .appName(app.getAppName())
                        .department(app.getDepartment())
                        .build());
    }

    @Override
    @Transactional
    public AppsNameResponse updateApp(Long id, AppsNameRequest request) {
        AppsName app = appsNameRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("App not found with id: " + id));

        app.setAppName(request.getAppName());
        app.setDepartment(request.getDepartment());
        AppsName updatedApp = appsNameRepository.save(app);
        log.info("App updated successfully with ID: {}", updatedApp.getId());

        return AppsNameResponse.builder()
                .id(updatedApp.getId())
                .appName(updatedApp.getAppName())
                .department(updatedApp.getDepartment())
                .build();
    }

    @Override
    @Transactional
    public void deleteApp(Long id) {
        AppsName app = appsNameRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("App not found with id: " + id));
        appsNameRepository.delete(app);
        log.info("App deleted successfully with ID: {}", id);
    }

    @Override
    public List<AppsNameResponse> getAppsByDepartment(String department) {
        return appsNameRepository.findByDepartment(department).stream()
                .map(app -> AppsNameResponse.builder()
                        .id(app.getId())
                        .appName(app.getAppName())
                        .department(app.getDepartment())
                        .build())
                .collect(Collectors.toList());
    }
}