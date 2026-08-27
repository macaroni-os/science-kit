# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
inherit autotools xdg

DESCRIPTION="A collection of data files to add support for chemical MIME types"
HOMEPAGE="https://github.com/dleidert/chemical-mime"
SRC_URI="https://github.com/dleidert/chemical-mime/archive/4fd66e3b3b7d922555d1e25587908b036805c45b.tar.gz -> chemical-mime-data-0.1.95_pre20171122-4fd66e3.tar.gz"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
BDEPEND="dev-libs/libxslt
	dev-util/intltool
	dev-util/desktop-file-utils
	virtual/pkgconfig
	
"
RDEPEND="x11-misc/shared-mime-info
	
"
DEPEND="${RDEPEND}
"
post_src_unpack() {
	mv chemical-mime-* ${S}
}
src_prepare() {
	default
	# https://github.com/dleidert/chemical-mime/issues/4
	sed -i -e \
		'/<_comment/a\\t\t<generic-icon name="image-x-generic"/>' \
		src/chemical-mime-database.xml.in || die
	sed -i -e \
		's:acronym|alias|comment|:acronym|alias|comment|generic-icon|:' \
		xsl/cmd_freedesktop_org.xsl || die
	eautoreconf
}
src_configure() {
	econf \
		--disable-update-database \
		--without-gnome-mime \
		--without-kde-mime \
		--without-kde-magic
}


# vim: filetype=ebuild
