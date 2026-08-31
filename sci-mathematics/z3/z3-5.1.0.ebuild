# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
PYTHON_COMPAT=( python3+ )
CMAKE_BUILD_TYPE=RelWithDebInfo
inherit cmake python-single-r1 toolchain-funcs

DESCRIPTION="The Z3 Theorem Prover"
HOMEPAGE="https://github.com/Z3Prover/z3"
SRC_URI="https://api.github.com/repos/Z3Prover/z3/tarball/refs/tags/z3-5.1.0 -> z3-5.1.0-0b6cdcd.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples gmp isabelle java openmp python"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RDEPEND="${PYTHON_DEPS}
	gmp? ( dev-libs/gmp:= )
	
"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	java? ( virtual/jdk )
	
"

post_src_unpack() {
	mv Z3Prover-z3-* ${S}
}


pkg_setup() {
  python_setup
}
src_configure() {
  local mycmakeargs=(
    -DCMAKE_INSTALL_DOCDIR="${EPREFIX}/usr/share/doc/${P}"
    -DUSE_LIB_GMP=$(usex gmp)
    -DUSE_OPENMP=$(usex openmp)
    -DENABLE_EXAMPLE_TARGETS=OFF
    -DBUILD_DOCUMENTATION=$(usex doc)
    -DBUILD_PYTHON_BINDINGS=$(usex python)
    -DBUILD_JAVA_BINDINGS=$(usex java)
  )
  cmake_src_configure
}
src_install() {
cmake_src_install
dodoc README.md
use examples && dodoc -r examples
use python && python_optimize
if use isabelle; then
insinto /usr/share/Isabelle/contrib/${P}/etc
newins - settings <<-EOF
Z3_COMPONENT="\$COMPONENT"
Z3_HOME="${EPREFIX}/usr/bin"
Z3_SOLVER="${EPREFIX}/usr/bin/z3"
Z3_REMOTE_SOLVER="z3"
Z3_VERSION="${PV}"
Z3_INSTALLED="yes"
Z3_NON_COMMERCIAL="yes"
EOF
fi
}
pkg_postinst() {
if use isabelle; then
if [[ -f ${ROOT%/}/etc/isabelle/components ]]; then
sed -e "/contrib\/${PN}-[0-9.]*/d" \
  -i "${ROOT%/}/etc/isabelle/components" || die
cat <<-EOF >> "${ROOT%/}/etc/isabelle/components" || die
contrib/${P}
EOF
fi
fi
}
pkg_postrm() {
  if use isabelle; then
    if [[ ! ${REPLACING_VERSIONS} ]]; then
      if [[ -f "${ROOT%/}/etc/isabelle/components" ]]; then
        # Note: this sed should only match the version of this ebuild
        # Which is what we want as we do not want to remove the line
        # of a new Isabelle component being installed during an upgrade.
        sed -e "/contrib\/${P}/d" \
          -i "${ROOT%/}/etc/isabelle/components" || die
      fi
    fi
  fi
}



# vim: filetype=ebuild
