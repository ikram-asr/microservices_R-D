package com.rd.project.repository;

import com.rd.project.model.Project;
import com.rd.project.model.ProjectStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProjectRepository extends JpaRepository<Project, Long> {
    List<Project> findByResearcherId(Long researcherId);
    List<Project> findByStatus(ProjectStatus status);
}

