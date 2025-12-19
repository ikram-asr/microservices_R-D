package com.rd.project.repository;

import com.rd.project.model.Phase;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PhaseRepository extends JpaRepository<Phase, Long> {
    List<Phase> findByIdProject(Long idProject);
}

