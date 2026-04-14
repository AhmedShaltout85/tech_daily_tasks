package com.ao8r.tasks_api.service;

import com.ao8r.tasks_api.dto.SignupRequest;
import com.ao8r.tasks_api.entity.Role;
import com.ao8r.tasks_api.entity.User;

import java.util.List;
import java.util.Optional;

public interface UserService {

    User registerUser(SignupRequest request);

    Optional<User> findByUsername(String username);

    Boolean existsByUsername(String username);

    List<User> findByRole(Role role);

    List<User> findByRoleAndIsEnabled(Role role, boolean isEnabled);

    User updateUserEnabled(Long id, boolean enabled);

    void deleteUser(Long id);

    void changePassword(String username, String currentPassword, String newPassword);

    void resetPassword(String username, String newPassword);

    List<String> getAllRoles();
}
