package com.rd.validation.service;

import com.rd.validation.dto.ValidationRequest;
import com.rd.validation.dto.ValidationResponse;
import com.rd.validation.model.Validation;
import com.rd.validation.model.ValidationStatus;
import com.rd.validation.repository.ValidationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ValidationService {

    @Autowired
    private ValidationRepository validationRepository;

    public List<ValidationResponse> getAllValidations() {
        return validationRepository.findAll().stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public List<ValidationResponse> getValidationsByProject(Long projectId) {
        return validationRepository.findByProjectId(projectId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public ValidationResponse getValidationById(Long id) {
        Validation validation = validationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Validation not found"));
        return toResponse(validation);
    }

    @Transactional
    public ValidationResponse createValidation(ValidationRequest request, Long validatorId) {
        Validation validation = new Validation();
        validation.setProjectId(request.getProjectId());
        validation.setValidatorId(validatorId);
        validation.setStatus(request.getStatus() != null ? request.getStatus() : ValidationStatus.PENDING);
        validation.setComments(request.getComments());
        validation.setValidationLevel(request.getValidationLevel() != null ? request.getValidationLevel() : 1);

        validation = validationRepository.save(validation);
        return toResponse(validation);
    }

    @Transactional
    public ValidationResponse updateValidation(Long id, ValidationRequest request, Long validatorId) {
        Validation validation = validationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Validation not found"));

        if (!validation.getValidatorId().equals(validatorId)) {
            throw new RuntimeException("Unauthorized to update this validation");
        }

        if (request.getStatus() != null) {
            validation.setStatus(request.getStatus());
        }
        if (request.getComments() != null) {
            validation.setComments(request.getComments());
        }
        if (request.getValidationLevel() != null) {
            validation.setValidationLevel(request.getValidationLevel());
        }

        validation = validationRepository.save(validation);
        return toResponse(validation);
    }

    private ValidationResponse toResponse(Validation validation) {
        return new ValidationResponse(
                validation.getId(),
                validation.getProjectId(),
                validation.getValidatorId(),
                validation.getStatus(),
                validation.getComments(),
                validation.getValidationLevel(),
                validation.getCreatedAt(),
                validation.getUpdatedAt()
        );
    }
}

