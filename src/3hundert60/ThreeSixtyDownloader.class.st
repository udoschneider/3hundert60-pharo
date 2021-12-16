Class {
	#name : #ThreeSixtyDownloader,
	#superclass : #Object,
	#category : #'3hundert60'
}

{ #category : #'as yet unclassified' }
ThreeSixtyDownloader >> baseDirectoy [

	^ FileLocator desktop / 'munich360'
]

{ #category : #'as yet unclassified' }
ThreeSixtyDownloader >> baseUrl [

	^ 'https://3hundert60.me/tours/munich360data/ausblick_auf_munchen_18/<1p>/<2p>/<3p>_<4p>.jpg'
]

{ #category : #'as yet unclassified' }
ThreeSixtyDownloader >> doit [

	self doit: 1024
]

{ #category : #'as yet unclassified' }
ThreeSixtyDownloader >> doit: resolution [

	| baseDirectiory sides resolutions baseUrl resolutionIndex filename bytes |
	baseDirectiory := self baseDirectoy.

	sides := self sidesMapping.
	resolutions := self resolutionMapping.
	baseUrl := self baseUrl.

	baseDirectiory ensureCreateDirectory.

	resolutionIndex := resolutions at: resolution.
	[ :sideJob | 
	sideJob max: sides size.
	sides keysAndValuesDo: [ :sideName :sideIndex | 
		| dir url sideForm |
		sideJob
			title: sideName asString;
			increment.
		sideForm := Form extent: resolution @ resolution depth: 32.
		dir := (baseDirectiory / sideName) ensureCreateDirectory.
		[ :vJob | 
		vJob
			title: 'V';
			max: resolution / 512.
		(0 to: (resolution / 512) - 1) do: [ :v | 
			vJob increment.
			[ :uJob | 
			uJob
				title: 'U';
				max: resolution / 512.
			(0 to: (resolution / 512) - 1) do: [ :u | 
				|response|
				uJob increment.
				url := baseUrl
					       expandMacrosWith: resolutionIndex
					       with: sideIndex
					       with: v
					       with: u.
				filename := '<1p>_<2p>.jpg' expandMacrosWith: v with: u.
					response := (bytes := ZnEasy get: url).
					response isSuccess ifTrue:[
				dir / filename binaryWriteStreamDo: [ :stream | 
					|  contents form |
				
					contents := response contents.
					stream nextPutAll: contents.
					form := ImageReadWriter formFromStream: contents readStream.
					"form inspect"

					sideForm
						copy: ((u*512) @ (v*512) extent: 512 @ 512)
						from: 0 @ 0
						in: form
						rule: Form paint] ] ] ] asJob run ] ] asJob run.
		(baseDirectiory / sideName, 'jpeg') binaryWriteStreamDo: [ :stream |
			PluginBasedJPEGReadWriter putForm: sideForm onStream: stream.
			 ] ] ] asJob run
]

{ #category : #'as yet unclassified' }
ThreeSixtyDownloader >> doitSingle: resolution [

	| baseDirectiory sides resolutions baseUrl resolutionIndex filename bytes |
	baseDirectiory := self baseDirectoy.

	sides := self sidesMapping.
	resolutions := self resolutionMapping.
	baseUrl := self baseUrl.

	baseDirectiory ensureCreateDirectory.

	resolutionIndex := resolutions at: resolution.
	[ :sideJob | 
	sideJob max: sides size.
	sides keysAndValuesDo: [ :sideName :sideIndex | 
		| dir url |
		sideJob
			title: sideName asString;
			increment.
		dir := (baseDirectiory / sideName) ensureCreateDirectory.
		[ :vJob | 
		vJob
			title: 'V';
			max: resolution / 512 - 1.
		(0 to: resolution / 512 - 1) do: [ :v | 
			vJob increment.
			[ :uJob | 
			uJob
				title: 'U';
				max: resolution / 512 - 1.
			(0 to: resolution / 512 - 1) do: [ :u | 
				uJob increment.
				url := baseUrl
					       expandMacrosWith: resolutionIndex
					       with: sideIndex
					       with: v
					       with: u.
				filename := '<1p>_<2p>.jpg' expandMacrosWith: v with: u.
				dir / filename binaryWriteStreamDo: [ :stream | 
					stream nextPutAll: (bytes := ZnEasy get: url) contents ] ] ]
				asJob run ] ] asJob run ] ] asJob run
]

{ #category : #'as yet unclassified' }
ThreeSixtyDownloader >> resolutionMapping [

	^ { 
		  (5632 -> 3).
		  (3072 -> 2).
		  (1536 -> 1).
		  (1024 -> 0) } asDictionary
]

{ #category : #'as yet unclassified' }
ThreeSixtyDownloader >> sidesMapping [

	^ { 
		  (#front -> 0).
		  (#right -> 1).
		  (#back -> 2).
		  (#left -> 3).
		  (#up -> 4).
		  (#down -> 6) } asDictionary
]
