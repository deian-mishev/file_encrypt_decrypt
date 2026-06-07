package com.encrypto.filters;

import java.io.IOException;
import java.time.Instant;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.core.Ordered;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.core.annotation.Order;

@Order(Ordered.HIGHEST_PRECEDENCE)
public class ApiOriginFilter extends OncePerRequestFilter {
    Logger logger = LoggerFactory.getLogger(ApiOriginFilter.class);

    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        String reqOrigin = request.getHeader("Origin");
        logger.info("Origin:: " + reqOrigin + " Request URL::" + request.getRequestURL().toString() + " Start Time="
                + Instant.now());
        filterChain.doFilter(request, response);
    }
}
