# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="PROJ - Cartographic Projections and Coordinate Transformations Library proj"
HOMEPAGE="https://proj.org/"
SRC_URI="https://github.com/OSGeo/proj/tarball/65c84b6e2a40ec8e6b8d1de86bcd556d01ef2aeb -> proj-9.0.0-65c84b6.tar.gz"

LICENSE="MIT"
# Changes on every major release
SLOT="0/$(ver_cut 1)"
KEYWORDS="*"
IUSE="curl test +tiff"

RESTRICT="!test? ( test )"

RDEPEND="dev-db/sqlite:3
	curl? ( net-misc/curl )
	tiff? ( media-libs/tiff )"
DEPEND="${RDEPEND}
	test? ( dev-cpp/gtest )"

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv OSGeo-proj* "${S}" || die
	fi
}

src_configure() {
	local mycmakeargs=(
		-DDOCDIR="${EPREFIX}"/usr/share/${PF}
		-DBUILD_TESTING=$(usex test)
		-DENABLE_CURL=$(usex curl)
		-DBUILD_PROJSYNC=$(usex curl)
		-DENABLE_TIFF=$(usex tiff)
	)

	use test && mycmakeargs+=( -DUSE_EXTERNAL_GTEST=ON )

	cmake_src_configure
}

src_test() {
	local myctestargs=(
		# proj_test_cpp_api: https://lists.osgeo.org/pipermail/proj/2019-September/008836.html
		# testprojinfo: Also related to map data?
		-E "(proj_test_cpp_api|testprojinfo)"
	)

	cmake_src_test
}

src_install() {
	cmake_src_install

	cd data || die
	dodoc README.DATA

	find "${ED}" -name '*.la' -type f -delete || die
}