args = $(foreach a,$($(subst -,_,$1)_args),$(if $(value $a),$a="$($a)"))

# Only install if apt is on system, otherwise do nothing
# Using oneliner to avoid messing around with makefile if statements
dependencies : bash-dependencies python-dependencies

bash-dependencies:
	(! command -v apt > /dev/null;) || sudo apt install -y libpq-dev

python-dependencies : requirements.txt
	python3 -m pip install -r requirements.txt

clean:
	rm -rf target
install :
	prefix=/usr/local
	export prefix
	(cd src; prefix=/usr/local make install)
package:
	mkdir -p target/bin
	(cd src; make)
	tar czf target/misc-toolkit_${version}.orig.tar.gz src --transform "s#src#misc-toolkit-${version}#"
	(cd target; tar xf misc-toolkit_${version}.orig.tar.gz;)
	cp -r debian target/misc-toolkit-${version}/debian
	(cd target/misc-toolkit-${version}; debuild -S -us -uc;)

publish:
	debsign -k 5DB475563E94EEAC666956FD31CA7EECE167B1C8 ./target/misc-toolkit_${version}_source.changes
	dput -f code-faster ./target/misc-toolkit_${version}_source.changes
