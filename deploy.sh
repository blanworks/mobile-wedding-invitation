#!/bin/bash

# 색상 정의
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 오류 처리 함수
handle_error() {
    echo -e "${RED}오류: $1${NC}"
    exit 1
}

# 서버 빌드 및 배포 통합 함수
# 매개변수: $1 - 서버 타입 ("ktor" 또는 "spring")
build_server() {
    echo -e "${GREEN} 서버 빌드 중...${NC}"

    # 빌드 단계
    if ! docker build --platform linux/amd64 -t repo.blan.works/wedding-card:latest .; then
        handle_error "Docker 빌드 실패, 배포 단계를 건너뜁니다."
    fi

    echo -e "${GREEN} 서버 빌드 완료, 이미지 푸시 중...${NC}"

    # 푸시 단계
    if ! docker push repo.blan.works/wedding-card; then
        handle_error "Docker 이미지 푸시 실패, 배포 단계를 건너뜁니다."
    fi

    echo -e "${GREEN} 이미지 푸시 완료${NC}"
    echo -e "${GREEN} 서버 빌드 완료${NC}"
}

# 사용하지 않는 Docker 이미지 정리
cleanup_docker_images() {
    echo -e "${CYAN}사용하지 않는 Docker 이미지 정리 중...${NC}"
    docker image prune -af || echo -e "${YELLOW}경고: Docker 이미지 정리 중 오류 발생${NC}"
    echo -e "${CYAN}Docker 이미지 정리 완료${NC}"
}

# 사용법 출력
print_usage() {
    echo -e "${YELLOW}사용법: $0 ${NC}"
    echo -e "${YELLOW}  wedding-card react(vite) 빌드 후 microk8s 로 배포(nginx)${NC}"
    exit 0
}

# 메인 로직
echo -e "${CYAN}Docker 빌드 및 SSH 배포 스크립트 시작${NC}"

build_server
if ! ssh blanworks-home deploy/deploy_wedding_card.sh; then
    handle_error "wedding-card 원격 배포 실패"
fi

# Docker 이미지 정리
cleanup_docker_images

echo -e "${CYAN}스크립트 실행 완료${NC}"