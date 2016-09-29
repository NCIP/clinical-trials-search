SELECT
  json_build_object(
    'nci_id', study.nci_id,
    'nct_id', study.nct_id,
    'protocol_id', study.lead_org_id,
    'ccr_id', study.ccr_id,
    'ctep_id', study.ctep_id,
    'dcp_id', study.dcp_id,
    'other_ids', (
      SELECT
        json_agg(
          json_build_object(
            'name', other_identifier.name,
            'value', other_identifier.value
          )
        )
      FROM
        dw_study_other_identifier other_identifier
      WHERE
        study.nci_id = other_identifier.nci_id
    ),

    'associated_studies', (
      SELECT
        json_agg(
          json_build_object(
            'study_id', association.study_b,
            'study_id_type', association.identifier_type
          )
        )
      FROM
        dw_study_association association
      WHERE
        study.nci_id = association.study_a
    ),

    'amendment_date', study.amendment_date,
    'current_trial_status', study.current_trial_status,
    'current_trial_status_date', study.current_trial_status_date,
    'start_date', study.start_date,
    'start_date_type_code', study.start_date_type_code,
    'completion_date', study.completion_date,
    'completion_date_type_code', study.completion_date_type_code,
    'record_verification_date', study.record_verification_date,
    'brief_title', study.brief_title,
    'official_title', study.official_title,
    'acronym', study.acronym,
    -- 'keyword_text', study.keyword_text,
    'keywords', (
      string_to_array(study.keyword_text, ', ')
    ),
    'brief_summary', study.brief_summary,
    'detail_description', study.detail_description,
    'classification_code', study.classification_code,
    'interventional_model', study.interventional_model,
    -- 'funding_category', study.summary_4_funding_category,
    -- 'expanded_access_indicator', study.expanded_access_indicator,
    'accepts_healthy_volunteers_indicator', study.accepts_healthy_volunteers_indicator,
    -- 'fdaregulated_indicator', study.fdaregulated_indicator,
    'study_protocol_type', study.study_protocol_type,
    'study_subtype_code', study.study_subtype_code,
    'study_population_description', study.study_population_description,
    'study_model_code', study.study_model_code,
    'study_model_other_text', study.study_model_other_text,
    'sampling_method_code', study.sampling_method_code,
    'bio_specimen', (
      'bio_specimen_description', study.bio_specimen_description,
      'bio_specimen_retention_code', study.bio_specimen_retention_code
    ),
    'primary_purpose', (
      json_build_object(
        'primary_purpose_code', study.primary_purpose_code,
        'primary_purpose_other_text', study.primary_purpose_other_text,
        'primary_purpose_additional_qualifier_code', study.primary_purpose_additional_qualifier_code
      )
    ),
    'phase', (
      json_build_object(
        'phase', study.phase,
        'phase_other_text', study.phase_other_text,
        'phase_additional_qualifier_code', study.phase_additional_qualifier_code
      )
    ),
    'masking', (
      json_build_object(
        'masking', study.masking,
        'masking_allocation_code', study.masking_allocation_code,
        'masking_role_investigator', study.masking_role_investigator,
        'masking_role_outcome_assessor', study.masking_role_outcome_assessor,
        'masking_role_subject', study.masking_role_subject,
        'masking_role_caregiver', study.masking_role_caregiver
      )
    ),

    'principal_investigator', study.principal_investigator,
    'central_contact', (
      json_build_object(
        'central_contact_email', study.central_contact_email,
        'central_contact_name', study.central_contact_name,
        'central_contact_phone', study.central_contact_phone,
        'central_contact_type', study.central_contact_type
      )
    ),
    'lead_org', study.lead_org,
    'collaborators', (
      SELECT
        json_agg(
          json_build_object(
            'name', collaborator.name,
            'functional_role', collaborator.functional_role
          )
        )
      FROM
        dw_study_collaborator as collaborator
      WHERE
        study.nci_id = collaborator.nci_id
    ),
    'sites', (
      SELECT
        json_agg(
          json_build_object(
            'contact_email', site.contact_email,
            'contact_name', site.contact_name,
            'contact_phone', site.contact_phone,
            'generic_contact', site.generic_contact,
            'org', (
              SELECT
                json_build_object(
                  'address_line_1', org.address_line_1,
                  'address_line_2', org.address_line_2,
                  'postal_code', org.postal_code,
                  'city', org.city,
                  'state_or_province', org.state_or_province,
                  'country', org.country,
                  'name', org.name,
                  'status', org.status,
                  'status_date', org.status_date,
                  'email', org.email,
                  'fax', org.fax,
                  'phone', org.phone,
                  'tty', org.tty,
                  'family', org.family,
                  'org_to_family_relationship', org.org_to_family_relationship
                )
              FROM
                dw_organization org
              WHERE
                site.org_po_id = org.po_id
            ),
            'recruitment_status', site.recruitment_status,
            'recruitment_status_date', site.recruitment_status_date,
            -- 'target_accrual', site.target_accrual,
            -- 'program_code', site.program_code,
            'local_site_identifier', site.local_site_identifier
          )
        )
      FROM
        dw_study_participating_site site
      WHERE
        study.nci_id = site.nci_id
    ),

    'anatomic_sites', (
      SELECT
        json_agg(
          anatomic_site.anatomic_site_name
        )
      FROM
        dw_study_anatomic_site anatomic_site
      WHERE
        study.nci_id = anatomic_site.nci_id
    ),
    'diseases', (
      SELECT
        json_agg(
          json_build_object(
            'disease_code', disease.disease_code,
            'disease_preferred_name', disease.disease_preferred_name,
            'disease_menu_display_name', disease.disease_menu_display_name,
            'inclusion_indicator', disease.inclusion_indicator,
            'lead_disease_indicator', disease.lead_disease_indicator,
            'nci_thesaurus_concept_id', disease.nci_thesaurus_concept_id
          )
        )
      FROM
        dw_study_disease disease
      WHERE
        study.nci_id = disease.nci_id
    ),
    'biomarkers', (
      SELECT
        json_agg(
          json_build_object(
            'assay_purpose', biomarker.assay_purpose,
            'long_name', biomarker.long_name,
            'name', rtrim(split_part(biomarker.name, '(', 1)),
            'synonyms', (
		        select COALESCE (string_to_array((select((regexp_matches(name, '^.*?\((.*?)\)\s*$'))[1])), '; '), array[]::text[])
            ),
            'hugo_biomarker_code', biomarker.hugo_biomarker_code,
            'nt_term_identifier', biomarker.nt_term_identifier
          )
        )
      FROM
        dw_study_biomarker biomarker
      WHERE
        study.nci_id = biomarker.nci_id
    ),

    'minimum_target_accrual_number', study.minimum_target_accrual_number,
    -- 'accruals', (
    --   SELECT
    --     json_agg(
    --       json_build_object(
    --         'accrual_count', accrual.accrual_count,
    --         'count_type', accrual.count_type,
    --         'org_name', accrual.org_name,
    --         'org_org_family', accrual.org_org_family
    --       )
    --     )
    --   FROM
    --     dw_study_accrual_count accrual
    --   WHERE
    --     study.nci_id = accrual.nci_id
    -- ),

    'eligibility', (
      json_build_object(
        'structured', (
          json_build_object(
            'gender', study.eligible_gender,
            'max_age', study.eligible_max_age,
            'max_age_number', study.eligible_max_age_number,
            'max_age_unit', study.eligible_max_age_unit,
            'min_age', study.eligible_min_age,
            'min_age_number', study.eligible_min_age_number,
            'min_age_unit', study.eligible_min_age_unit
          )
        ),
        'unstructured', (
          SELECT
            json_agg(
              json_build_object(
                'display_order', eligibility.display_order,
                'inclusion_indicator', eligibility.inclusion_indicator,
                'description', eligibility.description
              )
              ORDER BY eligibility.display_order
            )
          FROM
            dw_study_eligibility_criteria eligibility
          WHERE
            study.nci_id = eligibility.nci_id
        )
      )
    ),

    'number_of_arms', study.number_of_arms,
    'arms', (
      SELECT
        json_agg(
          json_build_object(
            'arm_name', arm.arm_name,
            'arm_type', arm.arm_type,
            'arm_description', arm.arm_description,
            'interventions', arm.interventions
          )
        )
      FROM (
        SELECT
          nci_id,
          arm_name,
          arm_type,
          arm_description,
          coalesce(
            json_agg(
              json_build_object(
                'intervention_name', intervention_name,
                'intervention_type', intervention_type,
                'intervention_code', intervention_evs_c_code,
                'intervention_description', intervention_description
              )
            )
            filter(
              WHERE
                intervention_name IS NOT NULL OR
                intervention_type IS NOT NULL OR
                intervention_description IS NOT NULL
            ),
            '[]'
          ) as interventions
        FROM
          dw_study_arm_and_intervention
        WHERE
          study.nci_id = dw_study_arm_and_intervention.nci_id
        GROUP BY
          nci_id,
          arm_name,
          arm_type,
          arm_description
      ) AS arm
      WHERE
        study.nci_id = arm.nci_id
    )
  ) as trial_json_object
FROM
  dw_study study;
