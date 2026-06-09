package com.ao8r.tasks_api.service;

import com.ao8r.tasks_api.exception.RefreshTokenException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@Service
@Slf4j
public class RefreshTokenService {

    @Value("${jwt.refresh-token.expiration.ms}")
    private long refreshTokenExpirationMs;

    private final ConcurrentHashMap<String, RefreshTokenEntry> tokenStore = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<String, Set<String>> userTokenIndex = new ConcurrentHashMap<>();

    private static class RefreshTokenEntry {
        final String username;
        final Instant expiresAt;

        RefreshTokenEntry(String username, Instant expiresAt) {
            this.username = username;
            this.expiresAt = expiresAt;
        }
    }

    public String createRefreshToken(String username) {
        String token = UUID.randomUUID().toString();
        Instant expiresAt = Instant.now().plusMillis(refreshTokenExpirationMs);

        tokenStore.put(token, new RefreshTokenEntry(username, expiresAt));
        userTokenIndex.computeIfAbsent(username, k -> ConcurrentHashMap.newKeySet()).add(token);

        log.debug("Created refresh token for user: {}, expires at: {}", username, expiresAt);
        return token;
    }

    public boolean validateRefreshToken(String token) {
        RefreshTokenEntry entry = tokenStore.get(token);
        if (entry == null) {
            return false;
        }
        if (Instant.now().isAfter(entry.expiresAt)) {
            revokeRefreshToken(token);
            return false;
        }
        return true;
    }

    public String getUsernameFromRefreshToken(String token) {
        RefreshTokenEntry entry = tokenStore.get(token);
        if (entry == null) {
            throw new RefreshTokenException("Refresh token not found");
        }
        if (Instant.now().isAfter(entry.expiresAt)) {
            revokeRefreshToken(token);
            throw new RefreshTokenException("Refresh token has expired");
        }
        return entry.username;
    }

    public void revokeRefreshToken(String token) {
        RefreshTokenEntry entry = tokenStore.remove(token);
        if (entry != null) {
            Set<String> userTokens = userTokenIndex.get(entry.username);
            if (userTokens != null) {
                userTokens.remove(token);
                if (userTokens.isEmpty()) {
                    userTokenIndex.remove(entry.username);
                }
            }
            log.debug("Revoked refresh token for user: {}", entry.username);
        }
    }

    public void revokeAllRefreshTokensForUser(String username) {
        Set<String> tokens = userTokenIndex.remove(username);
        if (tokens != null) {
            for (String token : tokens) {
                tokenStore.remove(token);
            }
            log.debug("Revoked all refresh tokens for user: {}", username);
        }
    }
}
