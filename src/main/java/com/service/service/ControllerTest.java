package com.service.service;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ControllerTest {


    @GetMapping("teste")
    public ResponseEntity<String> teste() {
        return ResponseEntity.ok("teste");
    }
}
