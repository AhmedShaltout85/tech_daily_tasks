package com.ao8r.tasks_api.service;

import com.ao8r.tasks_api.dto.PreventiveItemRequest;
import com.ao8r.tasks_api.dto.PreventiveItemResponse;
import com.ao8r.tasks_api.entity.PreventiveItem;
import com.ao8r.tasks_api.exception.ResourceNotFoundException;
import com.ao8r.tasks_api.repository.PreventiveItemRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class PreventiveItemServiceImpl implements PreventiveItemService {

    private final PreventiveItemRepository preventiveItemRepository;
    private final JdbcTemplate jdbcTemplate;

    @Override
    @Transactional
    public PreventiveItemResponse createItem(PreventiveItemRequest request) {
        log.debug("Creating new preventive item: {}", request.getAppName());

        PreventiveItem item = PreventiveItem.builder()
                .appName(request.getAppName())
                .action(request.getAction())
                .department(request.getDepartment())
                .build();

        PreventiveItem savedItem = preventiveItemRepository.save(item);
        log.info("Preventive item created successfully with id: {}", savedItem.getId());

        return mapToResponse(savedItem);
    }

    @Override
    public List<PreventiveItemResponse> getAllItems() {
        log.debug("Fetching all preventive items");
        return preventiveItemRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public PreventiveItemResponse getItemById(Long id) {
        log.debug("Fetching preventive item by id: {}", id);
        PreventiveItem item = preventiveItemRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Preventive item not found with id: " + id));
        return mapToResponse(item);
    }

    @Override
    public List<PreventiveItemResponse> getItemByAppName(String appName) {
        log.debug("Fetching preventive items by app name: {}", appName);

        // Debug - show all app names in DB
        jdbcTemplate.queryForList("SELECT DISTINCT app_name FROM preventive_item")
            .forEach(row -> log.debug(">>> DB app_name: [{}]", row.get("app_name")));

        // Debug - show matching count with exact SQL
        Integer exactCount = jdbcTemplate.queryForObject(
//            "SELECT COUNT(*) FROM preventive_item WHERE TRIM(LOWER(app_name)) = TRIM(LOWER(?))",
                "SELECT COUNT(*) FROM preventive_item WHERE LOWER(app_name) = LOWER(?)",
            Integer.class, appName);
        log.debug(">>> Exact match count: {}", exactCount);

        int count = preventiveItemRepository.countByAppNameNative(appName);
        log.info("Native query count for app '{}': {}", appName, count);
        List<PreventiveItem> items = preventiveItemRepository.findAllByAppName(appName);
        if (items.isEmpty()) {
            throw new ResourceNotFoundException("Preventive item not found with app name: " + appName);
        }
        return items.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<String> getActionsByAppName(String appName) {
        log.debug("Fetching actions by app name: {}", appName);
        return preventiveItemRepository.findActionByAppName(appName);
    }

    @Override
    @Transactional
    public PreventiveItemResponse updateItem(Long id, PreventiveItemRequest request) {
        log.debug("Updating preventive item with id: {}", id);

        PreventiveItem item = preventiveItemRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Preventive item not found with id: " + id));

        item.setAppName(request.getAppName());
        item.setAction(request.getAction());

        PreventiveItem updatedItem = preventiveItemRepository.save(item);
        log.info("Preventive item updated successfully with id: {}", updatedItem.getId());

        return mapToResponse(updatedItem);
    }

    @Override
    @Transactional
    public void deleteItem(Long id) {
        log.debug("Deleting preventive item with id: {}", id);

        if (!preventiveItemRepository.existsById(id)) {
            throw new ResourceNotFoundException("Preventive item not found with id: " + id);
        }

        preventiveItemRepository.deleteById(id);
        log.info("Preventive item deleted successfully with id: {}", id);
    }

    private PreventiveItemResponse mapToResponse(PreventiveItem item) {
        return PreventiveItemResponse.builder()
                .id(item.getId())
                .appName(item.getAppName())
                .action(item.getAction())
                .build();
    }
}
