# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit unpacker xdg

RESTRICT="strip preserve-libs"
# TODO
# * use dict from tree, linguas
# * do src_test (use junit from tree?)


DESCRIPTION="IDE for the R language"
HOMEPAGE="
	http://www.rstudio.org
	https://github.com/rstudio/rstudio/"
SRC_URI="https://download1.rstudio.org/electron/jammy/amd64/rstudio-2024.09.0-375-amd64-debian.tar.gz -> rstudio-2024.09.0.375_x86_64.pkg.tar.gz"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="*"
IUSE=""


RDEPEND="
	dev-lang/R
"
DEPEND="${RDEPEND}"

S=${WORKDIR}

src_prepare() {
	eapply_user
}

src_install() {
    mkdir -p "${D}/opt/"
	cp -Rp "${S}/"* "${D}/opt/rstudio"

	mkdir -p "${D}/usr/share/applications"
	cp "${FILESDIR}/rstudio-bin.desktop" "${D}/usr/share/applications/rstudio-bin.desktop"

	dosym ../../opt/rstudio/rstudio /usr/bin/rstudio-bin
}

pkg_preinst() {
	xdg_pkg_preinst
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	xdg_icon_cache_update
}