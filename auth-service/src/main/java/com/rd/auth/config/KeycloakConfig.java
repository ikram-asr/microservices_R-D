package com.rd.auth.config;

import org.keycloak.OAuth2Constants;
import org.keycloak.admin.client.Keycloak;
import org.keycloak.admin.client.KeycloakBuilder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class KeycloakConfig {

    @Value("${keycloak.server-url:http://keycloak:8080}")
    private String serverUrl;

    @Value("${keycloak.realm:rd-microservices}")
    private String realm;

    @Value("${keycloak.client-id:rd-gateway}")
    private String clientId;

    @Value("${keycloak.client-secret:rd-gateway-secret-change-in-production}")
    private String clientSecret;

    @Bean
    public Keycloak keycloakAdmin() {
        return KeycloakBuilder.builder()
                .serverUrl(serverUrl)
                .realm(realm)
                .clientId(clientId)
                .clientSecret(clientSecret)
                .grantType(OAuth2Constants.CLIENT_CREDENTIALS)
                .build();
    }
}

