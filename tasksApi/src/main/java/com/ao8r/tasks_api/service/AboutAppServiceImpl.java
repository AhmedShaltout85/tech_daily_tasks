package com.ao8r.tasks_api.service;

import com.ao8r.tasks_api.dto.AboutAppRequest;
import com.ao8r.tasks_api.dto.AboutAppResponse;
import com.ao8r.tasks_api.entity.AboutApp;
import com.ao8r.tasks_api.exception.ResourceNotFoundException;
import com.ao8r.tasks_api.repository.AboutAppRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class AboutAppServiceImpl implements AboutAppService {

    private final AboutAppRepository aboutAppRepository;

    @Override
    @Transactional
    public AboutAppResponse createApp(AboutAppRequest request) {
        log.debug("Creating new about app: {}", request.getAppName());

        AboutApp aboutApp = AboutApp.builder()
                .appName(request.getAppName())
                .department(request.getDepartment())
                .recommended(request.getRecommended() != null ? request.getRecommended() : new ArrayList<>())
                .build();

        AboutApp savedApp = aboutAppRepository.save(aboutApp);
        log.info("About app created successfully with id: {}", savedApp.getId());

        return mapToResponse(savedApp);
    }

    @Override
    public List<AboutAppResponse> getAllApps() {
        log.debug("Fetching all about apps");
        return aboutAppRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public AboutAppResponse getAppById(Long id) {
        log.debug("Fetching about app by id: {}", id);
        AboutApp aboutApp = aboutAppRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("About app not found with id: " + id));
        return mapToResponse(aboutApp);
    }

    @Override
    public AboutAppResponse getAppByAppName(String appName) {
        log.debug("Fetching about app by app name: {}", appName);
        AboutApp aboutApp = aboutAppRepository.findByAppName(appName)
                .orElseThrow(() -> new ResourceNotFoundException("About app not found with app name: " + appName));
        return mapToResponse(aboutApp);
    }

    @Override
    public List<String> getRecommendedByAppName(String appName) {
        log.debug("Fetching recommended values by app name: {}", appName);
        AboutApp aboutApp = aboutAppRepository.findByAppName(appName)
                .orElseThrow(() -> new ResourceNotFoundException("About app not found with app name: " + appName));
        return aboutApp.getRecommended() != null ? aboutApp.getRecommended() : new ArrayList<>();
    }

    @Override
    @Transactional
    public AboutAppResponse updateApp(Long id, AboutAppRequest request) {
        log.debug("Updating about app with id: {}", id);

        AboutApp aboutApp = aboutAppRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("About app not found with id: " + id));

        aboutApp.setAppName(request.getAppName());
        aboutApp.setDepartment(request.getDepartment());
        if (request.getRecommended() != null) {
            aboutApp.setRecommended(request.getRecommended());
        }

        AboutApp updatedApp = aboutAppRepository.save(aboutApp);
        log.info("About app updated successfully with id: {}", updatedApp.getId());

        return mapToResponse(updatedApp);
    }

    @Override
    @Transactional
    public void deleteApp(Long id) {
        log.debug("Deleting about app with id: {}", id);

        if (!aboutAppRepository.existsById(id)) {
            throw new ResourceNotFoundException("About app not found with id: " + id);
        }

        aboutAppRepository.deleteById(id);
        log.info("About app deleted successfully with id: {}", id);
    }

    @Override
    public List<AboutAppResponse> getAppsByDepartment(String department) {
        log.debug("Fetching about apps by department: {}", department);
        return aboutAppRepository.findByDepartment(department).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    private AboutAppResponse mapToResponse(AboutApp aboutApp) {
        return AboutAppResponse.builder()
                .id(aboutApp.getId())
                .appName(aboutApp.getAppName())
                .department(aboutApp.getDepartment())
                .recommended(aboutApp.getRecommended() != null ? aboutApp.getRecommended() : new ArrayList<>())
                .build();
    }
}