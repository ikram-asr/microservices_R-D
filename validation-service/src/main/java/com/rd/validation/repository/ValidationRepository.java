package com.rd.validation.repository;

import com.rd.validation.model.Validation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ValidationRepository extends JpaRepository<Validation, Long> {
    List<Validation> findByIdProject(Long idProject);
    List<Validation> findByStatut(String statut);
}

