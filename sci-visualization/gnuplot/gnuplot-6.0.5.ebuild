# Distributed under the terms of the GNU General Public License v2
# Autogen by MARK Devkit

EAPI=7
WX_GTK_VER="3.0-gtk3"
GP_VERSION="${PV%.*}"
TEXMF="${EPREFIX}/usr/share/texmf-site"
inherit autotools toolchain-funcs wxwidgets

DESCRIPTION="Command-line driven interactive plotting program"
HOMEPAGE="http://www.gnuplot.info/"
SRC_URI="https://download.sourceforge.net/gnuplot/gnuplot-6.0.5.tar.gz -> gnuplot-6.0.5.tar.gz"
LICENSE="gnuplot"
SLOT="0"
KEYWORDS="*"
IUSE="bitmap cairo doc examples +gd gpic latex libcerf lua metafont metapost qt6 readline regis tgif wxwidgets X"
BDEPEND="virtual/pkgconfig
	qt6? ( dev-qt/qttools:6[linguist] )
	
"
RDEPEND="cairo? (
	  x11-libs/cairo
	  x11-libs/pango )
	gd? ( >=media-libs/gd-2.0.35-r3:2=[png] )
	latex? (
	  virtual/latex-base
	  lua? (
	    dev-tex/pgf
	    >=dev-texlive/texlive-latexrecommended-2008-r2 ) )
	libcerf? ( sci-libs/libcerf:= )
	lua? ( dev-lang/lua:0 )
	qt6? (
	  dev-qt/qt5compat:6
	  dev-qt/qtbase:6[gui]
	  dev-qt/qtsvg:6 )
	readline? ( sys-libs/readline:0= )
	wxwidgets? (
	  x11-libs/wxGTK:${WX_GTK_VER}=[X]
	  x11-libs/cairo
	  x11-libs/pango
	  x11-libs/gtk+:3 )
	X? (
	  x11-libs/libX11
	  x11-libs/libXaw )
	
"
DEPEND="${RDEPEND}
	X? ( x11-base/xorg-proto )
	
"
src_prepare() {
	default

	# Add special version identification as required by provision 2
	# of the gnuplot license
	sed -i -e "1s/.*/& (mark-macaroni revision ${PR})/" PATCHLEVEL || die

	eautoreconf

	# Make sure we don't mix build & host flags.
	sed -i \
		-e 's:@CPPFLAGS@:$(BUILD_CPPFLAGS):' \
		-e 's:@CFLAGS@:$(BUILD_CFLAGS):' \
		-e 's:@LDFLAGS@:$(BUILD_LDFLAGS):' \
		-e 's:@CC@:$(CC_FOR_BUILD):' \
		docs/Makefile.in || die
}

src_configure() {
	if ! use latex; then
		sed -i -e '/SUBDIRS/s/LaTeX//' share/Makefile.in || die
	fi

	use wxwidgets && setup-wxwidgets

	tc-export CC CXX
	tc-export_build_env BUILD_CC
	export CC_FOR_BUILD=${BUILD_CC}

	local myconf=(
		--with-texdir="${TEXMF}/tex/latex/${PN}"
		--with-readline=$(usex readline gnu builtin)
		$(use_with bitmap bitmap-terminals)
		$(use_with cairo)
		$(use_with gd)
		$(use_with gpic)
		$(use_with libcerf)
		$(use_with lua)
		$(use_with metafont)
		$(use_with metapost)
		$(use_with qt6 qt qt6)
		$(use_with regis)
		$(use_with tgif)
		$(use_with X x)
		--enable-stats
		$(use_enable wxwidgets)
		--without-amos
		--without-caca
		EMACS=no
	)

	econf "${myconf[@]}"
}

src_compile() {
	emake all
}

src_install() {
	emake DESTDIR="${D}" install

	dodoc BUGS NEWS PGPKEYS README* RELEASE_NOTES
	newdoc term/PostScript/README README-ps
	newdoc term/js/README README-js
	use lua && newdoc term/lua/README README-lua

	if use examples; then
		insinto /usr/share/${PN}/${GP_VERSION}
		doins -r demo
		rm "${ED}"/usr/share/${PN}/${GP_VERSION}/demo/{binary{1,2,3},dodecahedron.bin} || die
		rm "${ED}"/usr/share/${PN}/${GP_VERSION}/demo/plugin/*.{o,so} || die
	fi

	if use doc; then
		dodoc docs/gnuplot.pdf FAQ.pdf
		# Documentation for making PostScript files
		docinto psdoc
		dodoc docs/psdoc/{*.doc,*.tex,*.ps,*.gpi,README}
	fi
}

src_test() {
	emake check GNUTERM="dumb"
}

pkg_postinst() {
	use latex && texmf-update
}

pkg_postrm() {
	use latex && texmf-update
}


# vim: filetype=ebuild
