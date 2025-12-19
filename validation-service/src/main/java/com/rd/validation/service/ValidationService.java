package com.rd.validation.service;

import com.rd.validation.dto.ValidationRequest;
import com.rd.validation.dto.ValidationResponse;
import com.rd.validation.dao.entities.Validation;
import com.rd.validation.dao.repositories.ValidationRepository;
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

    public List<ValidationResponse> getValidationsByProject(Long idProject) {
        return validationRepository.findByIdProject(idProject).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    public ValidationResponse getValidationById(Long id) {
        Validation validation = validationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Validation not found"));
        return toResponse(validation);
    }

    @Transactional
    public ValidationResponse createValidation(ValidationRequest request) {
        Validation validation = new Validation();
        validation.setIdProject(request.getIdProject());
        validation.setNomTest(request.getNomTest());
        validation.setStatut(request.getStatut() != null ? request.getStatut() : "PENDING");

        validation = validationRepository.save(validation);
        return toResponse(validation);
    }

    @Transactional
    public ValidationResponse updateValidation(Long id, ValidationRequest request) {
        Validation validation = validationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Validation not found"));

        if (request.getNomTest() != null) {
            validation.setNomTest(request.getNomTest());
        }
        if (request.getStatut() != null) {
            validation.setStatut(request.getStatut());
        }

        validation = validationRepository.save(validation);
        return toResponse(validation);
    }

    private ValidationResponse toResponse(Validation validation) {
        return new ValidationResponse(
                validation.getIdValidation(),
                validation.getIdProject(),
                validation.getNomTest(),
                validation.getStatut(),
                validation.getCreatedAt(),
                validation.getUpdatedAt()
        );
    }
}

