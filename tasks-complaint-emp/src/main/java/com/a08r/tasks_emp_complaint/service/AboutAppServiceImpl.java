package com.a08r.tasks_emp_complaint.service;

import com.a08r.tasks_emp_complaint.dto.AboutAppRequest;
import com.a08r.tasks_emp_complaint.dto.AboutAppResponse;
import com.a08r.tasks_emp_complaint.entity.AboutApp;
import com.a08r.tasks_emp_complaint.exception.ResourceNotFoundException;
import com.a08r.tasks_emp_complaint.repository.AboutAppRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class AboutAppServiceImpl implements AboutAppService {

    private final AboutAppRepository aboutAppRepository;

    @Override
    @Transactional
    public AboutAppResponse createItem(AboutAppRequest request) {
        log.debug("Creating new about app: {}", request.getAppName());

        AboutApp item = AboutApp.builder()
                .appName(request.getAppName())
                .recommended(request.getRecommended())
                .department(request.getDepartment())
                .build();

        AboutApp savedItem = aboutAppRepository.save(item);
        log.info("About app created successfully with id: {}", savedItem.getId());

        return mapToResponse(savedItem);
    }

    @Override
    public List<AboutAppResponse> getAllItems() {
        log.debug("Fetching all about apps");
        return aboutAppRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public AboutAppResponse getItemById(Long id) {
        log.debug("Fetching about app by id: {}", id);
        AboutApp item = aboutAppRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("About app not found with id: " + id));
        return mapToResponse(item);
    }

    @Override
    @Transactional
    public AboutAppResponse updateItem(Long id, AboutAppRequest request) {
        log.debug("Updating about app with id: {}", id);

        AboutApp item = aboutAppRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("About app not found with id: " + id));

        item.setAppName(request.getAppName());
        item.setRecommended(request.getRecommended());
        item.setDepartment(request.getDepartment());

        AboutApp updatedItem = aboutAppRepository.save(item);
        log.info("About app updated successfully with id: {}", updatedItem.getId());

        return mapToResponse(updatedItem);
    }

    @Override
    @Transactional
    public void deleteItem(Long id) {
        log.debug("Deleting about app with id: {}", id);

        if (!aboutAppRepository.existsById(id)) {
            throw new ResourceNotFoundException("About app not found with id: " + id);
        }

        aboutAppRepository.deleteById(id);
        log.info("About app deleted successfully with id: {}", id);
    }

    @Override
    public List<AboutAppResponse> getByAppName(String appName) {
        return aboutAppRepository.findByAppName(appName).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<AboutAppResponse> getByDepartment(String department) {
        return aboutAppRepository.findByDepartment(department).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    private AboutAppResponse mapToResponse(AboutApp item) {
        return AboutAppResponse.builder()
                .id(item.getId())
                .appName(item.getAppName())
                .recommended(item.getRecommended())
                .department(item.getDepartment())
                .build();
    }
}
