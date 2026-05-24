package com.ao8r.tasks_api.repository;

import com.ao8r.tasks_api.entity.PreventiveItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

//@Repository
//public interface PreventiveItemRepository extends JpaRepository<PreventiveItem, Long> {
//
//@Query("SELECT p FROM PreventiveItem p WHERE LOWER(p.appName) = LOWER(:appName)")
//    List<PreventiveItem> findAllByAppName(String appName);
//
//    @Query("SELECT p.action FROM PreventiveItem p WHERE LOWER(p.appName) = LOWER(:appName)")
//List<String> findActionByAppName(String appName);
//
//    @Query(value = "SELECT COUNT(*) FROM preventive_item WHERE LOWER(app_name) = LOWER(:appName)", nativeQuery = true)
//    int countByAppNameNative(String appName);
//}
@Repository
public interface PreventiveItemRepository extends JpaRepository<PreventiveItem, Long> {

    @Query("SELECT p FROM PreventiveItem p WHERE LOWER(p.appName) = LOWER(:appName)")
    List<PreventiveItem> findAllByAppName(String appName);

    @Query("SELECT p.action FROM PreventiveItem p WHERE LOWER(p.appName) = LOWER(:appName)")
    List<String> findActionByAppName(String appName);

    // For SQL Server (older versions)
    @Query(value = "SELECT COUNT(*) FROM preventive_item WHERE LTRIM(RTRIM(LOWER(app_name))) = LTRIM(RTRIM(LOWER(:appName)))", nativeQuery = true)
    int countByAppNameNative(String appName);

//    // Alternative: Remove TRIM if you don't need it
//    @Query(value = "SELECT COUNT(*) FROM preventive_item WHERE LOWER(app_name) = LOWER(:appName)", nativeQuery = true)
//    int countByAppNameNative(String appName);
}