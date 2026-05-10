package com.ao8r.tasks_api.repository;

import com.ao8r.tasks_api.entity.PreventiveMaintenance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PreventiveMaintenanceRepository extends JpaRepository<PreventiveMaintenance, Long> {

    List<PreventiveMaintenance> findByAppName(String appName);

    List<PreventiveMaintenance> findByUsername(String username);

    List<PreventiveMaintenance> findByPlaceName(String placeName);

    List<PreventiveMaintenance> findBySubPlace(String subPlace);

    List<PreventiveMaintenance> findByIsRemote(Boolean isRemote);

    List<PreventiveMaintenance> findByAppNameAndUsername(String appName, String username);

    List<PreventiveMaintenance> findByAppNameAndPlaceName(String appName, String placeName);

    List<PreventiveMaintenance> findByUsernameAndPlaceName(String username, String placeName);

    List<PreventiveMaintenance> findByAppNameAndIsRemote(String appName, Boolean isRemote);

    List<PreventiveMaintenance> findByUsernameAndIsRemote(String username, Boolean isRemote);

    List<PreventiveMaintenance> findByPlaceNameAndIsRemote(String placeName, Boolean isRemote);
}