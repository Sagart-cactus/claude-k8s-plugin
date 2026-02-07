#!/usr/bin/env bash
set -euo pipefail

REQUIRED_CMDS=(kind kubectl kustomize tilt go kubebuilder)

missing=()
for cmd in "${REQUIRED_CMDS[@]}"; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    missing+=("$cmd")
  fi
done

if [ ${#missing[@]} -eq 0 ]; then
  echo "All prerequisites are installed: ${REQUIRED_CMDS[*]}"
  exit 0
fi

echo "Missing tools: ${missing[*]}"

# Auto-detect OS and package manager
OS="$(uname -s)"
PM=""
case "$OS" in
  Darwin)
    PM="brew"
    ;;
  Linux)
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      case "${ID:-}" in
        ubuntu|debian|pop|linuxmint)
          PM="apt"
          ;;
        fedora|rhel|centos|rocky|alma)
          if command -v dnf >/dev/null 2>&1; then
            PM="dnf"
          else
            PM="yum"
          fi
          ;;
        arch|manjaro)
          PM="pacman"
          ;;
      esac
    fi
    ;;
esac

if [ -z "$PM" ]; then
  echo "Could not detect package manager. Install manually: ${missing[*]}" >&2
  exit 1
fi

echo "Detected package manager: $PM"

install_with_brew() {
  local tool="$1"
  case "$tool" in
    kind)       brew install kind ;;
    kubectl)    brew install kubernetes-cli ;;
    kustomize)  brew install kustomize ;;
    tilt)       brew install tilt-dev/tap/tilt ;;
    go)         brew install go ;;
    kubebuilder) brew install kubebuilder ;;
  esac
}

install_with_apt() {
  local tool="$1"
  case "$tool" in
    kind)
      curl -fsSL "https://kind.sigs.k8s.io/dl/v0.25.0/kind-linux-amd64" -o /tmp/kind
      chmod +x /tmp/kind && sudo mv /tmp/kind /usr/local/bin/kind
      ;;
    kubectl)
      sudo apt-get update -qq && sudo apt-get install -y -qq kubectl 2>/dev/null \
        || { curl -fsSL "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /tmp/kubectl \
          && chmod +x /tmp/kubectl && sudo mv /tmp/kubectl /usr/local/bin/kubectl; }
      ;;
    kustomize)
      curl -fsSL "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
      sudo mv kustomize /usr/local/bin/
      ;;
    tilt)
      curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash
      ;;
    go)
      sudo apt-get update -qq && sudo apt-get install -y -qq golang
      ;;
    kubebuilder)
      curl -fsSL "https://go.kubebuilder.io/dl/latest/linux/amd64" -o /tmp/kubebuilder
      chmod +x /tmp/kubebuilder && sudo mv /tmp/kubebuilder /usr/local/bin/kubebuilder
      ;;
  esac
}

install_with_dnf() {
  local tool="$1"
  case "$tool" in
    kind)
      curl -fsSL "https://kind.sigs.k8s.io/dl/v0.25.0/kind-linux-amd64" -o /tmp/kind
      chmod +x /tmp/kind && sudo mv /tmp/kind /usr/local/bin/kind
      ;;
    kubectl)    sudo dnf install -y kubectl ;;
    kustomize)  sudo dnf install -y kustomize ;;
    tilt)
      curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash
      ;;
    go)         sudo dnf install -y golang ;;
    kubebuilder)
      curl -fsSL "https://go.kubebuilder.io/dl/latest/linux/amd64" -o /tmp/kubebuilder
      chmod +x /tmp/kubebuilder && sudo mv /tmp/kubebuilder /usr/local/bin/kubebuilder
      ;;
  esac
}

install_with_yum() {
  local tool="$1"
  case "$tool" in
    kind)
      curl -fsSL "https://kind.sigs.k8s.io/dl/v0.25.0/kind-linux-amd64" -o /tmp/kind
      chmod +x /tmp/kind && sudo mv /tmp/kind /usr/local/bin/kind
      ;;
    kubectl)    sudo yum install -y kubectl ;;
    kustomize)  sudo yum install -y kustomize ;;
    tilt)
      curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash
      ;;
    go)         sudo yum install -y golang ;;
    kubebuilder)
      curl -fsSL "https://go.kubebuilder.io/dl/latest/linux/amd64" -o /tmp/kubebuilder
      chmod +x /tmp/kubebuilder && sudo mv /tmp/kubebuilder /usr/local/bin/kubebuilder
      ;;
  esac
}

install_with_pacman() {
  local tool="$1"
  case "$tool" in
    kind)       sudo pacman -S --noconfirm kind ;;
    kubectl)    sudo pacman -S --noconfirm kubectl ;;
    kustomize)  sudo pacman -S --noconfirm kustomize ;;
    tilt)
      curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash
      ;;
    go)         sudo pacman -S --noconfirm go ;;
    kubebuilder)
      curl -fsSL "https://go.kubebuilder.io/dl/latest/linux/amd64" -o /tmp/kubebuilder
      chmod +x /tmp/kubebuilder && sudo mv /tmp/kubebuilder /usr/local/bin/kubebuilder
      ;;
  esac
}

echo "Installing missing tools using $PM..."
for tool in "${missing[@]}"; do
  echo "Installing $tool..."
  "install_with_${PM}" "$tool"
done

echo ""
echo "Re-checking prerequisites..."
still_missing=()
for cmd in "${REQUIRED_CMDS[@]}"; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    still_missing+=("$cmd")
  else
    echo "  $cmd: $(command -v "$cmd")"
  fi
done

if [ ${#still_missing[@]} -gt 0 ]; then
  echo ""
  echo "Still missing: ${still_missing[*]}" >&2
  echo "Please install these manually and re-run." >&2
  exit 1
fi

echo ""
echo "All prerequisites installed."
