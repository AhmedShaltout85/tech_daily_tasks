package com.a08r.tasks_emp_complaint.service;

import com.a08r.tasks_emp_complaint.dto.RetrieveEmpDataRequest;
import com.a08r.tasks_emp_complaint.dto.RetrieveEmpDataResponse;
import com.a08r.tasks_emp_complaint.entity.RetrieveEmpData;
import com.a08r.tasks_emp_complaint.exception.ResourceNotFoundException;
import com.a08r.tasks_emp_complaint.repository.RetrieveEmpDataRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class RetrieveEmpDataServiceImpl implements RetrieveEmpDataService {

    private final RetrieveEmpDataRepository retrieveEmpDataRepository;

    @Override
    @Transactional
    public RetrieveEmpDataResponse createItem(RetrieveEmpDataRequest request) {
        log.debug("Creating new retrieve_emp_data: empId={}", request.getEmpId());
        RetrieveEmpData item = RetrieveEmpData.builder()
                .empId(request.getEmpId())
                .empName(request.getEmpName())
                .empType(request.getEmpType())
                .empJob(request.getEmpJob())
                .empDegree(request.getEmpDegree())
                .empLocation(request.getEmpLocation())
                .empDept(request.getEmpDept())
                .empAdmin(request.getEmpAdmin())
                .empSector(request.getEmpSector())
                .build();
        RetrieveEmpData savedItem = retrieveEmpDataRepository.save(item);
        log.info("RetrieveEmpData created successfully with id: {}", savedItem.getId());
        return mapToResponse(savedItem);
    }

    @Override
    public List<RetrieveEmpDataResponse> getAllItems() {
        return retrieveEmpDataRepository.findAll()
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public RetrieveEmpDataResponse getItemById(Integer id) {
        RetrieveEmpData item = retrieveEmpDataRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("RetrieveEmpData not found with id: " + id));
        return mapToResponse(item);
    }

    @Override
    @Transactional
    public RetrieveEmpDataResponse updateItem(Integer id, RetrieveEmpDataRequest request) {
        RetrieveEmpData item = retrieveEmpDataRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("RetrieveEmpData not found with id: " + id));

        item.setEmpId(request.getEmpId());
        item.setEmpName(request.getEmpName());
        item.setEmpType(request.getEmpType());
        item.setEmpJob(request.getEmpJob());
        item.setEmpDegree(request.getEmpDegree());
        item.setEmpLocation(request.getEmpLocation());
        item.setEmpDept(request.getEmpDept());
        item.setEmpAdmin(request.getEmpAdmin());
        item.setEmpSector(request.getEmpSector());

        RetrieveEmpData updatedItem = retrieveEmpDataRepository.save(item);
        log.info("RetrieveEmpData updated successfully with id: {}", id);
        return mapToResponse(updatedItem);
    }

    @Override
    @Transactional
    public void deleteItem(Integer id) {
        if (!retrieveEmpDataRepository.existsById(id)) {
            throw new ResourceNotFoundException("RetrieveEmpData not found with id: " + id);
        }
        retrieveEmpDataRepository.deleteById(id);
        log.info("RetrieveEmpData deleted successfully with id: {}", id);
    }

    @Override
    public List<RetrieveEmpDataResponse> getByEmpId(Integer empId) {
        return retrieveEmpDataRepository.findByEmpId(empId)
                .stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    @Override
    public List<RetrieveEmpDataResponse> getByEmpName(String empName) {
        return retrieveEmpDataRepository.findByEmpName(empName)
                .stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    @Override
    public List<RetrieveEmpDataResponse> getByEmpType(String empType) {
        return retrieveEmpDataRepository.findByEmpType(empType)
                .stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    @Override
    public List<RetrieveEmpDataResponse> getByEmpJob(String empJob) {
        return retrieveEmpDataRepository.findByEmpJob(empJob)
                .stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    @Override
    public List<RetrieveEmpDataResponse> getByEmpDegree(String empDegree) {
        return retrieveEmpDataRepository.findByEmpDegree(empDegree)
                .stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    @Override
    public List<RetrieveEmpDataResponse> getByEmpLocation(String empLocation) {
        return retrieveEmpDataRepository.findByEmpLocation(empLocation)
                .stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    @Override
    public List<RetrieveEmpDataResponse> getByEmpDept(String empDept) {
        return retrieveEmpDataRepository.findByEmpDept(empDept)
                .stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    @Override
    public List<RetrieveEmpDataResponse> getByEmpAdmin(String empAdmin) {
        return retrieveEmpDataRepository.findByEmpAdmin(empAdmin)
                .stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    @Override
    public List<RetrieveEmpDataResponse> getByEmpSector(String empSector) {
        return retrieveEmpDataRepository.findByEmpSector(empSector)
                .stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    @Override
    public List<RetrieveEmpDataResponse> getByEmpIdAndEmpDept(Integer empId, String empDept) {
        return retrieveEmpDataRepository.findByEmpIdAndEmpDept(empId, empDept)
                .stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    @Override
    public List<RetrieveEmpDataResponse> getByEmpDeptAndEmpLocation(String empDept, String empLocation) {
        return retrieveEmpDataRepository.findByEmpDeptAndEmpLocation(empDept, empLocation)
                .stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    @Override
    public List<RetrieveEmpDataResponse> getByEmpIdAndEmpLocation(Integer empId, String empLocation) {
        return retrieveEmpDataRepository.findByEmpIdAndEmpLocation(empId, empLocation)
                .stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    private RetrieveEmpDataResponse mapToResponse(RetrieveEmpData item) {
        return RetrieveEmpDataResponse.builder()
                .id(item.getId())
                .empId(item.getEmpId())
                .empName(item.getEmpName())
                .empType(item.getEmpType())
                .empJob(item.getEmpJob())
                .empDegree(item.getEmpDegree())
                .empLocation(item.getEmpLocation())
                .empDept(item.getEmpDept())
                .empAdmin(item.getEmpAdmin())
                .empSector(item.getEmpSector())
                .build();
    }
}
